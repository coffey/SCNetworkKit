var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
    var result = {};
    result['status'] = 200;
    res.write(JSON.stringify(result));
    res.end();
});

router.post('/', function(req, res, next) {
  var result = {};
    result['status'] = 200;
    result['msg'] = req.body;
    console.log(req.body);
    res.write(JSON.stringify(result));
    res.end();
});

module.exports = router;
