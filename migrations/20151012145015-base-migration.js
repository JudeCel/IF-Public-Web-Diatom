'use strict';
var fs = require('fs');

module.exports = {
  up: function (queryInterface, Sequelize) {
    var db = queryInterface.sequelize;

    function createTables(data){
      db.query(data.toString()).done(function(err, data){
        if (err) throw err;
      });
    };

    fs.readFile(__dirname +'/../db/structure.sql', function(err, data){
      if (err) throw err;
      createTables(data);
    });
  },

  down: function (queryInterface, Sequelize) {
    return queryInterface.dropAllTables();
  }
};
