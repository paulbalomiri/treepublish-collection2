if Package['aldeed:collection2']
  ###
  Crude type checking for link types
  
  To use it extent the initial SimpleSchema initialization argument like so:

  mySchema= new SimpleSchema(_.extend({otherfield:{type:object} , TP.link_schema("link_field", true)) 
  @name  The field name
  @opt the link field options

  TODO: only true is accepted by now as an argument to link_schema
  TODO: Somehow hook into simpleschema to allow for definition of subfields based on a single field.
       Ideally the user should provide only link:config and not need this function.

  ###
  TP.link_schema = (name, opt)->
    if not  opts?  or (_.isBoolean(opts) and opts)
      ret= 
        link:
          link:true
          type:Object
        'link.link_id':
          type:String
        'link.link_collection':
          type:String
          optional:true
        'link.link_type':
          type:String
          optional:true

          
      return ret
  Meteor.Collection.prototype.attachSchema= _.wrap Meteor.Collection.prototype.attachSchema, (orig,schema,opts,other...)->
    if schema instanceof SimpleSchema
      console.error ("pba:treepublish-collection2: Not implemented. Please supply the SimpleSchema constructor argument as opposed to a SimpleSchema object")
    else
      for key, val of schema
        if 'link' of val
          _.extend schema, TP.link_schema key, val
          TP.links[TP.get_collection_name(this)]=_.object [[ key, val.link]]
      orig.call this, schema, opts,other...

  SimpleSchema.extendOptions
    link: Match.Optional Match.OneOf( 
        Boolean
      , 
        String
      , 
        Match.OneOf
          Match.ObjectIncluding
            target: Match.OneOf
              fixed: Match.OneOf String, Meteor.Collection
              ,
              default: Match.OneOf String, Meteor.Collection
            ,
          Match.ObjectIncluding
            type: Match.OneOf
              fixed: String
              ,
              default: String
      )
    SimpleSchema.addValidator ->
      console.log this
      if def= @definition.link
        
        unless @value?.link_id
          console.error "Error validating link:", @value
          return "missing_link_id"
        unless @value?.link_collection or  @value?.link_type
          console.error "Error validating link:", @value
          return "missing_collection_or_type"
    SimpleSchema.messages 
       missing_link_id: "[label] field is missing a target id (link_id)"
       missing_collection_or_type: "[label] field is missing a collection or a type (link_collection|link_type)"
  TP.init_from_simple_schema= (collections=TP.collections, links=TP.links)->
    err_already_defined= (col_name, keyname)->
      if links[col_name]?
        console.error err= "Collection #{col_name} is already configured[schema key: #{keyname}] ", "with ", schema[key]
        throw new Error(err)
   
    for col_name, col of collections
      col_name = TP.get_collection_name(col)
      if schema= col.simpleSchema?()?.schema?()
        already_config=links[col_name]?
        for key, config of schema
          if config.link?
            if already_config
              err_already_defined(col_name, key)
            links[col_name]?={}
            links[col_name][key]=config
    return links

else
  TP.init_from_simple_schema = ->
    err= '''Please add the collection2 package to use initFromSimpleSchema
        You can add the package with in your favourite shell like so:

        meteor add aldeed:collection2

    '''
    console.error err
    throw new Error(err)