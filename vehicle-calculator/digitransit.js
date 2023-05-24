const mqtt = require('mqtt');

const vehicles = new Set();
const client = mqtt.connect('wss://mqtt.digitransit.fi');
client.on('connect', () => client.subscribe('/#'));
client.on('message', (topic, message) => {
  const [
    ,
    ,
    ,
    feedId,
    ,
    ,
    ,
    ,
    ,
    ,
    tripId,
    ,
    startTime,
    ...rest
  ] = topic.split('/');
  const key = `${feedId}__${tripId}__${startTime}`;
  console.log(key)
  vehicles.add(key)
  console.log(vehicles.size)
})
