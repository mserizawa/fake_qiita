# FakeQiita

* Github like qiita my page.
* This is just a joke app.
* This is *alpha version* software.

## How to start

### Your local

First of all, install softwares below.

* elixir
* phoenix
* npm

Next, Setup your Qiita Application.
Please see [this page](http://help.qiita.com/ja/articles/qiita-team-application).

And then, set environments as below.

```sh
CLIENT_ID={ your client id of qiita app }
CLIENT_SECRET={ your client secret of qiita app }
ACCESS_TOKEN={ your access_token }
```

At the end, execute these commands.

```sh
$ git clone https://github.com/mserizawa/fake_qiita.git
$ cd fake_qiita/
$ npm install
$ mix deps.get
$ elixir --detached -S mix phoenix.server
```

## Recommended browser

* Chrome: latest
* Firefox: latest
* Safari: latest

## TODO

- [x] Discard 'Singin with Qiita'
- [ ] Separate layout and page
- [ ] Add Ajax Loading
- [ ] Handle Exceptions
- [ ] Improve caching TTL
