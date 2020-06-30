start
 = select _ columns:Columns _ from _ table:TableName whereCommand:(_ where _ Condition)? __ ';'?{
 	  // console.log('vvvvvvvv')
    // console.log('columns', columns)
    // console.log('whereCommand', whereCommand)
    // console.log('^^^^^^^')
    var result = `source=${table}`;
    
    // where条件
    var whereText = '';
    if(!!whereCommand) {
    	var where = whereCommand[3];
        for(let  key in where) {
        	whereText += ` ${key}=${where[key]}`
        }
        result += `${whereText}`
    }
    
    // 查询的字段：如果查某个字段，不是*
    if(Array.isArray(columns)) {
    	result += ` | FIELDS ${columns.join(',')}`
    }
    
   return result
 }

// select，忽略大小写
select = "SELECT"i
from = "FROM"i
where = "WHERE"i
and = "AND"i

// 来源
TableName
 = name:Field+ {
   return name.join("")
 }
 
// 搜索的字段
Columns 'Columns'
  = '(' __ first:Field rest:MoreFields* __ ')' {
  	// console.log(first, rest)
    return [first].concat(rest)
  }
  / name:Field+ {
   return name
 }
 / '*'

MoreFields 'MoreFields'
  = ','? _? field:Field { return field }

// where条件
Condition 'Condition'
 = '(' __ first:ConditionCommand rest:MoreConditions* __ ')' {
 	  // console.log('Condition-first', first)
    // console.log('Condition-rest', rest)
    var arr = [first].concat(rest);
    var obj = {};
    for (var i=0; i<arr.length; i++) {
    	obj = Object.assign(obj, arr[i]);
    }
    return obj;
}

ConditionCommand
 = key:Field SEP value:Value {
	return ({[key]: value})
}
 
MoreConditions 'MoreConditions'
 = _? and? _? field:ConditionCommand { return field }

// 数字
Integer "integer"
  = _ [0-9]+ { return parseInt(text(), 10); }

_ = WhitespaceChar+
__ = WhitespaceChar*

WhitespaceChar = [ \t\r\n]

// 字段、表名等
Field = $[a-zA-Z0-9\._\-]+

// Glue
SEP
  = '='
  
 Value
  = $[a-zA-Z0-9\._\-]+
  
CommonSearchCommands
  = "chart"
  / "timechart"
  / "dedup"
  / "eval"
  / "fields"
  / "head"
  / "tail"
  / "lookup"
  / "rename"
  / "rex"
  / "search"
  / "sort"
  / "stats"
  / "mstats"
  / "table"
  / "top"
  / "rare"
  / "transaction"
  / "where"

CommonEvalFunctions
  = "abs"
  / "case"
  / "ceil"
  / "cidrmatch"
  / "coalesce"
  / "cos"
  / "exact"
  / "exp"
  / "if"
  / "isbool"
  / "isint"
  / "isnull"
  / "isstr"
  / "len"
  / "like"
  / "log"
  / "lower"
  / "ltrim"
  / "match"
  / "max"
  / "md5"
  / "min"
  / "mvcount"
  / "mvfilter"
  / "mvindex"
  / "mvjoin"
  / "now"
  / "null"
  / "nullif"
  / "random"
  / "relative_time"
  / "replace"
  / "round"
  / "rtrim"
  / "searchmatch"
  / "split"
  / "sqrt"
  / "strftime"
  / "strptime"
  / "substr"
  / "time"
  / "tonumber"
  / "tostring"
  / "typeof"
  / "urldecode"
  / "validate"

CommonStatsFunctions
  = "avg"
  / "count"
  / "dc"
  / "earliest"
  / "latest"
  / "max"
  / "median"
  / "min"
  / "mode"
  / "perc<X>"
  / "range"
  / "stdev"
  / "stdevp"
  / "sum"
  / "sumsq"
  / "values"
  / "var"