
<muut-demo>

  <header>
    <strong if={ logged }>{ data.user.displayname } &bull;</strong>
    <a if={ !logged } onclick={ login }>Log in</a>
    <a if={ logged } onclick={ logout }>Log out</a>
  </header>

  <div class="thread" each={ threads }>
    <img class="avatar" src={ seed.user.img }>

    <main>
      <h3>{ seed.title }</h3>
      <p each={ para in seed.body }>{ para }</p>
    </main>

    <!-- replies -->
    <div class="reply" each={ replies }>
      <img class="avatar" src={ user.img }>
      <main>
        <p each={ para in body }>{ para }</p>
      </main>
    </div>

    <form onsubmit={ reply } if={ logged }>
      <textarea name="area"/>
      <p>
        <button>Reply</button>
      </p>
    </form>

  </div>


  var data = opts.data,
    api = opts.api,
    self = this

  // context variables
  this.threads = data.moots.entries
  this.logged = data.user.path
  this.data = data


  // opens a new window (see util.js)
  login() {
    openLogin(api.session)
  }

  logout() {
    api.call('logout', { path: api.path }, function() {
      self.update({ logged: false })
    })
  }

  reply(e) {
    var thread = e.item,
      form = e.target

    var body = form.area.value.split('\n')

    api.call('reply', { path: thread.path, body: body, key: body[0].slice(0, 20) })

    thread.replies.push({ body: body, user: data.user })
    form.area.value = ''
    self.update()

  }

  /*
    Receive event upon succesfull login.

    Session info is stored in localStorage so subsequent initializations are authenticated.
  */
  api.on('login', function() {

    api.call('init', { path: api.path }, function(json) {
      self.threads = json.moots.entries
      self.data = data = json
      self.logged = true
      self.update()
    })
  })

  function getThread(path) {
    for (var i = 0, thread; (thread = self.threads[i]); i++) {
      if (thread.path == path) return thread
    }
  }

  api.on('reply', function(path, reply) {
    var thread = getThread(path)
    if (thread) {
      thread.replies.push(reply)
      self.update()
    }
  })

</muut-demo>