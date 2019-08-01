var schema = require('@colyseus/schema');
var colyseus = require('colyseus');
var social = require('@colyseus/social');

class Message extends schema.Schema {
    constructor(message) {
        super();
        this.message = message;
    }
}
schema.type("string")(Message.prototype, "message");

class Player extends schema.Schema {
    constructor(args) {
        super();
        this.x = args.x;
        this.y = args.y;
    }
}
schema.type("number")(Player.prototype, "x");
schema.type("number")(Player.prototype, "y");

class State extends schema.Schema {
    constructor() {
        super();
        this.messages = new schema.ArraySchema(new Message("That's the first message."));
        this.players = new schema.MapSchema();
    }
}
schema.type([ Message ])(State.prototype, "messages");
schema.type({ map: Player })(State.prototype, "players");
schema.type("string")(State.prototype, "turn");

class ChatRoomSchema extends colyseus.Room {

  onInit (options) {
    this.setState(new State());

    // for "get_available_rooms" (ROOM_LIST protocol)
    this.setMetadata({
      bool: true,
      str: "string",
      int: 10,
      nested: { hello: "world" }
    });

    this.setSimulationInterval( this.update.bind(this) );

    this.clock.setInterval(() => {
      this.state.turn = "turn" + Math.random()
    }, 1000);

    console.log("ChatRoom created!", options);
  }

  async onAuth(options) {
    // console.log("onAuth: ", options);
    return true //await social.User.findById(social.verifyToken(options.token)._id);
  }

  requestJoin (options) {
    console.log("request join!", options);
    return true;
  }

  onJoin (client, options, user) {
    console.log("client joined!", client.sessionId);

    console.log("User:", user);
    this.state.players[client.sessionId] = new Player({ x: 0, y: 0 });
    this.send(client, { hello: "world!" })
  }

  onLeave (client) {
    console.log("client left!", client.sessionId);
    delete this.state.players[client.sessionId];
  }

  onMessage (client, data) {
    this.broadcast({broadcasting: "something"});
    console.log(data, "received from", client.sessionId);
    this.state.messages.push(new Message(client.sessionId + " sent " + data));

    for (let message of this.state.messages) {
      message.message += "a";
    }
  }

  update () {
    for (var sessionId in this.state.players) {
      this.state.players[sessionId].x += 0.0001;
    }
  }

  onDispose () {
    console.log("Dispose ChatRoom");
  }

}

module.exports = ChatRoomSchema;
