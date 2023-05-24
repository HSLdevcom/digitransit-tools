const mqtt = require('mqtt');

const vehicles = new Set();
const client = mqtt.connect('wss://mqtt.hsl.fi');
client.on('connect', () => client.subscribe('/hfp/v2/journey/ongoing/#'));
client.on('message', (topic, message) => {
  const [
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    operatorId,
    vehicleId,
    ...rest // eslint-disable-line no-unused-vars
  ] = topic.split('/');
  const key = `${operatorId}__${vehicleId}`;
  console.log(key)
  vehicles.add(key)
  console.log(vehicles.size)
})
