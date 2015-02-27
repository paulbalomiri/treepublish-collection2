 Package.describe
    name: 'pba:treepublish-collection2'
    description: 'Reads treepublish config from collection2 schemas'
  Package.on_use (api) ->
    api.use [
      'pba:treepublish'
      'aldeed:simple-schema@1.3.0'
      'aldeed:collection2@2.3.2'
      'check'
      'coffeescript'
      'alethes:lodash@0.7.1'
    ]
    api.addFiles 'simpleschema.coffee', ['client','server']

    return