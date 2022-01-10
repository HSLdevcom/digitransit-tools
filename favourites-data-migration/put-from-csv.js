const csv = require('csv-parser');
const fs = require('fs');
const moment = require('moment');
const axios = require('axios');

const CSV_WITH_FAVOURITES = process.env.PATH_TO_CSV_FILE || 'dev-postal-area.csv';
const FAVOURITES_HOST = process.env.FAVOURITES_HOST
const code = process.env.CODE || '';

let count = 0;
let errorCount = 0;

const parser = csv({ separator: '\t' });

console.log('Migration started at', new Date().toString());

fs.createReadStream(CSV_WITH_FAVOURITES).pipe(parser);

const putFavourites = (favourites, hslid) => {
  parser.pause();
  axios.put(`${FAVOURITES_HOST}/api/favorites/${hslid}?store=fav&code=${code}`, favourites)
    .then(res => {
      count += 1;
      setTimeout(() => parser.resume(), 500);
    })
    .catch(error => {
      console.log('Failed: ' + error);
      console.log('UserId:', hslid, '\nFavs:\n', favourites);
      errorCount += 1;
      setTimeout(() => parser.resume(), 500);
    });
};

  
parser.on('data', (data) => {
    const newFaws = [];
    const fav = {
        type: 'postalCode',
        postalCode: data.PostalCode,
        lastUpdated: moment().unix(),
    };
    newFaws.push(fav);
    putFavourites(newFaws, data.UserId);
});

parser.on('end', () => {
    console.log(`Success count ${count}, error count ${errorCount}`);
    console.log(`Migration ended ${new Date().toString()}`);
});