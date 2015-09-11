Promise Tracker Campaign Builder
------------
Rails app for the creation of citizen monitoring campaigns. The campaign builder works in conjunction with the [Promise Tracker Data Aggregator](https://github.com/c4fcm/Promise-Tracker-Aggregator) and the [Promise Tracker Mobile Client](https://github.com/c4fcm/Promise-Tracker-Mobile).

Project info at: [promisetracker.org](http://promisetracker.org)

To Set Up
------------

1. Create an application.yml file based on template in config/application.yml.template. This file should contain the link and private key for an instace of the [Promise Tracker Data Aggregator](https://github.com/c4fcm/Promise-Tracker-Aggregator).
2. Create a database.yml file based on template in  config/database.yml.template.
3. `bundle install`
4. `rake db:setup`
5. `sudo apt-get install imagemagick -y`

To Run
----------

On your computer:
```shell
rails server
```

Or on c9:
```shell
rails s -b $IP -p $PORT
```

Deploying to Production
-----------------------

1. Make sure to compile the assets: `RAILS_ENV=production bin/rake assets:precompile`
2. Make sure to `sudo chown -R www-data:www-data public/` so the web user can save images