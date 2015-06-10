sheethub
========
[SheetHub](http://sheethub.co) lets you easily publish, share, and sell sheet music.

![SheetHub](http://i.imgur.com/HYwc8RY.png)

> Your files are securely hosted on SheetHub so you don't need to worry about building a website or storing files anywhere. SheetHub handles payments, sales, emails, and distribution. You'll also get your very own personal portfolio and subdomain! You are paid directly and instantly the moment you make a sale.

SheetHub handles all the technical complexities behind hosting and selling your sheet music online, so you can focus on pursuing your music.

I've been looking for a decent community/marketplace for sheet music and have been disappointed so far, so I decided to try my hand at building one. Thus, SheetHub was born.

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

- elasticsearch
- postgres

Additionally, you need to populate development environment [secrets.yml](https://github.com/Leventhan/sheethub/blob/master/config/secrets.yml) attributes before you can run the project on development. This means you'll have to register a number of external services, such as AWS S3 and PayPal Sandbox when running locally as well as `redis` and `memcached` when running on a staging server. See the `secrets.yml` file for more details.

Message me if you need help!

## Getting Started

```
bundle install
rake db:migrate
rails s
```

## Application Overview

SheetHub is built on **Rails 4.2** and uses **Ruby 2.2.0**.

The latest entity-relationship diagram for all the model objects can be viewed [here](https://github.com/Leventhan/sheethub/blob/master/erd.pdf). You can update the erd.pdf file based on the current schema using the following command:

```
bundle exec erd
```

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
- and [many.](http://blog.sheethub.co/post/113654779988/new-purchase-status-page) [more.](http://blog.sheethub.co/post/114997377358/march-updates) [features.](http://blog.sheethub.co/post/107029226688/introducing-preview-mode)

## API

SheetHub provides a **read-only JSON API** for all public sheets. You can view the endpoints via [this Postman collection](https://www.getpostman.com/collections/d17c3262d1904a279a76). Note that you need an API Key to access the API. On development, create an new *ApiKey* object and use the token generated. The SheetHub API uses HTTP Token authentication. On production, [message me](mailto:yosriady@gmail.com) and I'll give you an API Key.

Both on development and production, use [Postman](https://www.getpostman.com/) to play around with the endpoints. The collection above comes with all the following available endpoints:

- `POST` /v1/sheets/search
- `GET` v1/sheets
- `GET` v1/sheets/:id
- `GET` v1/users
- `GET` v1/users/:id

> Postman is a powerful API testing suite which has become a must-have tool for many developers.

The SheetHub API provides pagination support.

```
/sheets?page=<page_number>
```

The API is namespaced to an `api` subdomain like so:

```
http://api.sheethub.co/v1/sheets
```

You can use the API to build applications that interact with SheetHub's user-curated database of sheet music and musicians. Admittedly, the available data you can currently pull from the API is still sparse.

## Subdomain Configuration

Since SheetHub uses subdomains extensively for user profile pages (such as `edwinsungmusic.sheethub.co`), you won't be able to use `localhost` for local development. Instead, you must use `lvh.me`. Read [this](https://reinteractive.net/posts/199-developing-and-testing-rails-applications-with-subdomains) for more details.

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
