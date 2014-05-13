# RUIAN Rails importer example

## Install

```
bundle install
bundle exec rake db:setup
```

## Start import

```
bundle rake ruian:update_all
bundle rake ruian:import
```

## How it works

See example lib/tasks/ruian.rake for details about ruian:import task. Mainly example/lib/importer.rb is used for importing.

'Interface' is defined in lib/ruian/importer.rb.

Update tasks are defined in lib/tasks/ruian.rake.
