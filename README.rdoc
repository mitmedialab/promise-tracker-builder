== Promise Tracker
=== Data collection for civic action

Promise Tracker is a citizen monitoring platform that allows communities to design and implement local data collection campaigns. Through the online platform, users can create new campaigns, design custom surveys, track responses collected via the mobile app, and visualize data.

To Set Up
------------

1. Create an application.yml file based on template in config/application.yml.template. This file should contain the link and private key for an instace of the {Promise Tracker Data Aggregator}[https://github.com/c4fcm/Promise-Tracker-Aggregator].
2. Create a database.yml file based on template in  config/database.yml.template.
3. `rake db:setup`
4. `sudo apt-get install imagemagick -y`

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