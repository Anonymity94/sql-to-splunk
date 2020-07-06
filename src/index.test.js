#!/usr/bin/env node
const pegjs = require('pegjs')
const fs = require('fs')

const pegRule = fs.readFileSync('sql.pegjs', 'utf8')
// @see: https://pegjs.org/documentation#installation-node-js
const parser = pegjs.generate(pegRule)

describe('sql to splunk spl test', () => {
  const sql1 = 'SELECT * FROM mytable;'
  test(sql1, () => {
    const result1 = parser.parse(sql1)
    expect(result1).toBe('source=mytable')
  })

  const sql2 = 'SELECT old FROM mytable;'
  test(sql2, () => {
    const result2 = parser.parse(sql2)
    expect(result2).toBe('source=mytable | FIELDS old')
  })

  const sql3 = 'SELECT (old, age) FROM mytable where ( name=23 );'
  const result3 = parser.parse(sql3)
  test(sql3, () => {
    const result3 = parser.parse(sql3)
    expect(result3).toBe('source=mytable name=23 | FIELDS old, age')
  })

  const sql4 = 'SELECT (old, age) FROM mytable where ( name=23 and time=324 );'
  test(sql4, () => {
    const result4 = parser.parse(sql4)
    expect(result4).toBe('source=mytable name=23 time=324 | FIELDS old, age')
  })
})
