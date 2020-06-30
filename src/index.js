#!/usr/bin/env node
const pegjs = require('pegjs')
const fs = require('fs')
const chalk = require('chalk')

fs.readFile('splunk.pegjs', 'utf8', function(err, data) {
  if (err) {
    return console.log(err)
  }

  // @see: https://pegjs.org/documentation#installation-node-js
  var parser = pegjs.generate(data)

  var result1 = parser.parse('SELECT * FROM mytable;')
  console.log('result1 ==>', chalk.green(result1))

  var result2 = parser.parse('SELECT old FROM mytable;')
  console.log('result2 ==>', chalk.green(result2))

  var result3 = parser.parse(
    'SELECT (old, age) FROM mytable where ( name=23 );'
  )
  console.log('result3 ==>', chalk.green(result3))

  var result4 = parser.parse(
    'SELECT (old, age) FROM mytable where ( name=23 and time=324 );'
  )
  console.log('result4 ==>', chalk.green(result4))
})
