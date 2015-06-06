sheethub
========
[SheetHub](http://sheethub.co) lets you easily publish, share, and sell sheet music.

SheetHub is **open source** since 7 June 2015. It's been a one-man show up to this point, so mind some unnecessary complexity! Contributions are most welcome! 

## System Requirements
'''
brew install <requirement>
'''

- elasticsearch
- libpng
- libjpeg
- imagemagick

```
brew install <requirement>
```

You also need the following running:
- Postgres

## Getting Started

```
bundle install
rake db:migrate
rails s
```

## Application Overview
TODO


## Contributing

Here are some ideas you can work on:
- Audio Player on sheet pages
- Allow Users to Organize Composition Competitions/Jams
- Allow Arrangement licensing of original pieces on SheetHub. Users can submit arrangements of original pieces on SheetHub and sell it, sharing payments back with the original author
- jobs.sheethub.co: Job Board for Musicians
- Use background jobs with Active Job + Sidekiq
- Missing unit tests
- *Your idea here!*

Register your interest by creating a new Github issue.

Get in touch with me so I can help you get started!
You'll need to add some config .yml files before you can run the project on development. 
