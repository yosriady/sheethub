sheethub
========
[SheetHub](http://sheethub.co) lets you easily publish, share, and sell sheet music.

> I started playing classical guitar at a young age and regularly play in my spare time. I've been looking for a decent community/marketplace for sheet music and have been disappointed so far, so I decided to try my hand at building one.

SheetHub is **open source** since 7 June 2015. It's been a one-man show up to this point, so mind some unnecessary complexity! Contributions are most welcome! 

## System Requirements
You'll need the following installed on your machine:

- elasticsearch
- libpng
- libjpeg
- imagemagick

For each of the above, do:

```
brew install <requirement>
```

You also need the following running:

- Postgres

Additionally, you need to populate development environment [secrets.yml](https://github.com/Leventhan/sheethub/blob/master/config/secrets.yml) attributes before you can run the project on development. This means you'll have to register a number of external services, such as AWS S3, PayPal locally as well as redis, memcached on a staging server. Message me if you need help!

## Getting Started

```
bundle install
rake db:migrate
rails s
```

## Application Overview
SheetHub lets you easily publish, share, and sell your music.

Your files are securely hosted on SheetHub so you don't need to worry about building a website or storing files anywhere. We help you handle everything from payments, sales, emails, and distribution. You'll also get your very own personal portfolio and subdomain! You are paid directly and instantly the moment you make a sale.

SheetHub handles all the technical complexities behind hosting and selling your sheet music online, so you can focus on pursuing your music.

SheetHub is on Rails 4.2. 

The latest entity-relationship diagram can be viewed [here](https://github.com/Leventhan/sheethub/blob/master/erd.pdf).

Current features include:

- [Secure file storage and delivery](http://blog.sheethub.co/post/106303300248/host-multiple-files-on-sheethub)
- [Payment processing](http://sheethub.co/support#payment-flow)
- SEO optimizations
- [PDF Stamping](http://blog.sheethub.co/post/106303315798/protect-your-work-with-pdf-stamping)
- User profile pages
- [Sales analytics](http://blog.sheethub.co/post/107397378618/new-geographic-sales-chart)
- Copyright reporting
- [License-limited purchase options](http://blog.sheethub.co/post/114052450803/new-limited-purchases)
- [Pay-what-you-want pricing](http://blog.sheethub.co/post/106303328028/earn-more-with-pay-what-you-want-pricing)
- User Discussions
- [Browser PDF Viewer](http://blog.sheethub.co/post/115381704368/new-pdf-viewer)
- Personalized recommendations
- [Tags](http://blog.sheethub.co/post/106303181373/describing-your-work-with-tags) and [advanced filtering](http://blog.sheethub.co/post/114032147643/improved-search)
- User Likes/Favorites
- [EU VAT Compliance](http://blog.sheethub.co/post/106770902463/2015-vat-compliance-with-sheethub)
- Premium Memberships
- and [many.](http://blog.sheethub.co/post/113654779988/new-purchase-status-page) [other.](http://blog.sheethub.co/post/114997377358/march-updates) [features.](http://blog.sheethub.co/post/107029226688/introducing-preview-mode)

## Contributing

Here are some ideas you can work on:
- Audio Player on sheet pages
- Organize composition competitions
- Allow Arrangement licensing of original pieces on SheetHub. Users can submit arrangements of original pieces on SheetHub and sell it, sharing payments back with the original author
- jobs.sheethub.co
- Use background jobs with Active Job + Sidekiq
- Missing unit tests
- Performance optimizations
- Fix typos
- *Your idea here!*

Discuss ideas by creating a Github issue!
