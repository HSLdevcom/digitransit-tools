const fs = require('fs');
const path = require('path');
const XmlStream = require('xml-stream');
const moment = require('moment');
const axios = require('axios');

const XML_WITH_FAVOURITES = process.env.PATH_TO_XML_FILE || 'favlines.xml';
const readStream = fs.createReadStream(path.join(__dirname, XML_WITH_FAVOURITES));

const xml = new XmlStream(readStream);

let count = 0;
let errorCount = 0;

const putFavourites = (favourites, hslid) => {
  xml.pause();
  const FAVOURITES_HOST = process.env.FAVOURITES_HOST;
  const code = process.env.CODE || '';
  axios.put(`${FAVOURITES_HOST}/api/favorites/${hslid}?code=${code}`, favourites)
    .then(res => {
      console.log(res.status);
      count += 1;
      setTimeout(function () {
        xml.resume();
      }, 500);
    })
    .catch(error => {
      console.log('Failed with status code: ' + error);
      errorCount += 1;
      setTimeout(function () {
        xml.resume();
      }, 500);
    });
};
console.log(`Migration started ${moment().toString()}`);
xml.collect('line');
xml.on('endElement: user', function(item) {
  if (item.hslid) {
    const hslid = item.hslid;
    const lines = item.lines.line;
    const newFavs = [];
    lines.forEach(line => {
      newFavs.push({
        type: 'route',
        gtfsId: line.gtfsid,
        lastUpdated: moment().unix(),
      });
    });
    console.log(`add new favourites for ${item['e-mail']} with hslid ${hslid}`);
    console.log(newFavs);
    putFavourites(newFavs, hslid);
  } else {
    console.log(`User ${item['e-mail']} missing hslid, skipping...`)
  }
  console.log(`Success count ${count}, error count ${errorCount}`);
});

xml.on('end', function() {
  console.log(`Success count ${count}, error count ${errorCount}`);
  console.log(`Migration ended ${moment().toString()}`);
});
