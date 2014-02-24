Octospy
=======

[![Gem Version](https://badge.fury.io/rb/octospy.png)][gem]
[![Build Status](https://secure.travis-ci.org/linyows/octospy.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/linyows/octospy.png?travis)][gemnasium]
[![Code Climate](https://codeclimate.com/github/linyows/octospy.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/linyows/octospy/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/octospy
[travis]: http://travis-ci.org/linyows/octospy
[gemnasium]: https://gemnasium.com/linyows/octospy
[codeclimate]: https://codeclimate.com/github/linyows/octospy
[coveralls]: https://coveralls.io/r/linyows/octospy

Octospy notifies the repository activity to some IRC channels.

<div align="center">
<img src="http://octodex.github.com/images/daftpunktocat-thomas.gif" width="300">
<img src="http://octodex.github.com/images/daftpunktocat-guy.gif" width="300">
</div>

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'octospy'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install octospy
```

Usage
-----

```sh
$ mv .emv.example .env
```

edit `.env`:

```sh
SERVER=irc.yourserver.net
CHANNELS=yourchannel
GITHUB_LOGIN=yourusername
GITHUB_TOKEN=e17e1c6caa3e452433ab55****************
```

github tokens: https://github.com/settings/applications

```sh
$ octospy
```

Commands
--------

format: `octospy: <command>`

Command                          | Description
-------                          | -----------
`watch <repository>`             | add repository to watch list (ex: watch rails/rails)
`unwatch <repository>`           | remove repository to watch list
`watch <user or organization>`   | add user's repositories to watch list (ex: watch dotcloud)
`unwatch <user or organization>` | remove user's repositories to watch list(ex: watch dotcloud)
`job start`                      | start the repository event monitoring
`job stop`                       | stop the repository event monitoring
`join <channel>`                 | invite octospy to another channel
`show watched`                   | display the watch list
`show status`                    | display the joined channels

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Authors
-------

- [linyows](https://github.com/linyows)

License
-------

The MIT License (MIT)
