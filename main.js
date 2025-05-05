const fs = require('fs');

fs.writeFileSync('output.txt', 'File successfully created!\n', 'utf8');
console.log('output.txt created!');
