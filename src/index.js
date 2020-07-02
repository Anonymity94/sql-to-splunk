#!/usr/bin/env node
const pegjs = require('pegjs')
const fs = require('fs')
const chalk = require('chalk')

const pegRule = fs.readFileSync('splunk.pegjs', 'utf8')
// @see: https://pegjs.org/documentation#installation-node-js
const parser = pegjs.generate(pegRule)

const sql1 = 'SELECT * FROM mytable;'
const result1 = parser.parse(sql1)
console.log('result1 ==>', chalk.green(result1))

const result2 = parser.parse('SELECT old FROM mytable;')
console.log('result2 ==>', chalk.green(result2))

const result3 = parser.parse(
  'SELECT (old, age) FROM mytable where ( name=23 );'
)
console.log('result3 ==>', chalk.green(result3))

const result4 = parser.parse(
  'SELECT (old, age) FROM mytable where ( name=23 and time=324 );'
)
console.log('result4 ==>', chalk.green(result4))
