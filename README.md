# SQLtoSplunk

> 完整的sql解析：[sql.pegjs](https://github.com/alsotang/sql.pegjs) 

## Usage
```sh
$ yarn
$ npm run start
```

## Features

|       | SQL command       | SQL example                                                  | Splunk SPL example                                           |
| ----- | :---------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| ✅ | SELECT *          | `SELECT * FROM mytable `                                     | `source=mytable `                                            |
| ✅ | WHERE             | `SELECT * FROM mytable WHERE (mycolumn=5) `                    | `source=mytable mycolumn=5 `                                 |
| ✅ | SELECT            | `SELECT (mycolumn1, mycolumn2) FROM mytable `                  | `source=mytable	 | FIELDS mycolumn1, mycolumn2 `          |
|       | AND/OR            | `SELECT * FROM mytable WHERE (mycolumn1="true"    OR mycolumn2="red")  AND mycolumn3="blue" ` | `source=mytable AND (mycolumn1="true"    OR mycolumn2="red") AND mycolumn3="blue" `**Note:** The AND operator is implied in SPL and does not need to be specified. For this example you could also use:`source=mytable (mycolumn1="true"    OR mycolumn2="red") mycolumn3="blue" ` |
|       | AS (alias)        | `SELECT mycolumn AS column_alias FROM mytable `              | `source=mytable | RENAME mycolumn as column_alias | FIELDS column_alias ` |
|       | BETWEEN           | `SELECT * FROM mytable WHERE mycolumn BETWEEN 1 AND 5 `      | `source=mytable    mycolumn>=1 mycolumn<=5 `                 |
|       | GROUP BY          | `SELECT mycolumn, avg(mycolumn) FROM mytable WHERE mycolumn=value GROUP BY mycolumn ` | `source=mytable mycolumn=value | STATS avg(mycolumn) BY mycolumn | FIELDS mycolumn, avg(mycolumn) `Several commands use a `by-clause` to group information, including [chart](http://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/Chart), [rare](http://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/Rare), [sort](http://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/Sort), [stats](http://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/Stats), and [timechart](http://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/Timechart). |
|       | HAVING            | `SELECT mycolumn, avg(mycolumn) FROM mytable WHERE mycolumn=value GROUP BY mycolumn HAVING avg(mycolumn)=value ` | `source=mytable mycolumn=value | STATS avg(mycolumn) BY mycolumn | SEARCH avg(mycolumn)=value | FIELDS mycolumn, avg(mycolumn) ` |
|       | LIKE              | `SELECT * FROM mytable WHERE mycolumn LIKE "%some text%" `   | `source=mytable    mycolumn="*some text*" `**Note:** The most common search in Splunk SPL is nearly impossible in SQL - to search all fields for a substring. The following SPL search returns all rows that contain "some text" anywhere:`source=mytable "some text"  ` |
|       | ORDER BY          | `SELECT * FROM mytable ORDER BY mycolumn desc `              | `source=mytable | SORT -mycolumn `In SPL you use a negative sign ( - ) in front of a field name to sort in descending order. |
|       | SELECT DISTINCT   | `SELECT DISTINCT    mycolumn1, mycolumn2 FROM mytable `      | `source=mytable | DEDUP mycolumn1 | FIELDS mycolumn1, mycolumn2 ` |
|       | SELECT TOP        | `SELECT TOP(5)  mycolum1,  mycolum2 FROM mytable1 WHERE mycolum3 = "bar" ORDER BY mycolum1 mycolum2 ` | `Source=mytable1 mycolum3="bar" | FIELDS mycolum1 mycolum2 | SORT mycolum1 mycolum2 | HEAD 5 ` |
|       | INNER JOIN        | `SELECT * FROM mytable1 INNER JOIN mytable2 ON mytable1.mycolumn=    mytable2.mycolumn ` | `index=myIndex1 OR index=myIndex2 | stats values(*) AS * BY myField `**Note:** There are two other methods to join tables:Use the `lookup` command to add fields from an external table:`... | LOOKUP myvaluelookup    mycolumn    OUTPUT myoutputcolumn `Use a subsearch:`source=mytable1   [SEARCH source=mytable2      mycolumn2=myvalue     | FIELDS mycolumn2] `If the columns that you want to join on have different names, use the `rename` command to rename one of the columns. For example, to rename the column in mytable2:`source=mytable1  | JOIN type=inner mycolumn    [ SEARCH source=mytable2      | RENAME mycolumn2      AS mycolumn] `To rename the column in myindex1:`index=myIndex1 OR index=myIndex2 | rename myfield1 as myField | stats values(*) AS * BY myField `You can rename a column regardless of whether you use the search command, a lookup, or a subsearch. |
|       | LEFT (OUTER) JOIN | `SELECT * FROM mytable1 LEFT JOIN mytable2 ON mytable1.mycolumn=   mytable2.mycolumn ` | `source=mytable1 | JOIN type=left mycolumn    [SEARCH source=mytable2] ` |
|       | SELECT INTO       | `SELECT * INTO new_mytable IN mydb2 FROM old_mytable `       | `source=old_mytable | EVAL source=new_mytable | COLLECT index=mydb2 `**Note:** COLLECT is typically used to store expensively calculated fields back into your Splunk deployment so that future access is much faster. This current example is atypical but shown for comparison to the SQL command. The source will be renamed orig_source |
|       | TRUNCATE TABLE    | `TRUNCATE TABLE mytable `                                    | `source=mytable | DELETE `                                   |
|       | INSERT INTO       | `INSERT INTO mytable VALUES (value1, value2, value3,....) `  | **Note:** see SELECT INTO. Individual records are not added via the search language, but can be added via the API if need be. |
|       | UNION             | `SELECT mycolumn FROM mytable1 UNION SELECT mycolumn FROM mytable2 ` | `source=mytable1 | APPEND    [SEARCH source=mytable2] | DEDUP mycolumn ` |
|       | UNION ALL         | `SELECT * FROM mytable1 UNION ALL SELECT * FROM mytable2 `   | `source=mytable1 | APPEND    [SEARCH source=mytable2]  `     |
|       | DELETE            | `DELETE FROM mytable WHERE mycolumn=5 `                      | `source=mytable1 mycolumn=5 | DELETE `                       |
|       | UPDATE            | `UPDATE mytable SET column1=value,    column2=value,... WHERE some_column=some_value ` | **Note:** There are a few things to think about when updating records in Splunk Enterprise. First, you can just add the new values to your Splunk deployment (see INSERT INTO) and not worry about deleting the old values, because Splunk software always returns the most recent results first. Second, on retrieval, you can always de-duplicate the results to ensure only the latest values are used (see SELECT DISTINCT). Finally, you can actually delete the old records (see DELETE). |



## Links

- [Splunk Search Commands](https://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/Abstract)
- [Splunk Quick Reference Guide](https://docs.splunk.com/Documentation/SplunkCloud/7.2.9/SearchReference/SplunkEnterpriseQuickReferenceGuide)([pdf下载](https://www.splunk.com/content/dam/splunk2/pdfs/solution-guides/splunk-quick-reference-guide.pdf))
- [From SQL to Splunk SPL](https://docs.splunk.com/Documentation/Splunk/6.5.0/SearchReference/SQLtoSplunk)
- [PEG.js online](https://pegjs.org/online)
- [PEG.js Parsing Expression Types](https://pegjs.org/documentation#grammar-syntax-and-semantics-parsing-expression-types)