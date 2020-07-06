{
  var FIELDS = 'FIELDS';
  var RENAME = 'RENAME';
}

start
  = SELECT _ columns:ColumnCommand _ FROM _ table:TableName where:(_ WHERE _ WhereCommand)? __ ';'?{
    var dsl = `source=${table}`;
    
    // where条件
    if(!!where) {
    	var whereString = where[3];
        dsl += ` ${whereString}`
    }
    
    // 搜索的字段
    dsl += columns;
    
    return dsl
  }

SELECT = "SELECT"i
FROM = "FROM"i
WHERE = "WHERE"i
AND = "AND"i
AS = "AS"i
OR = "OR"i
LIKE = "LIKE"i
GROUP_BY = "GROUP BY"i

// 数据来源表名
TableName
  = name:Field+ {
    return name.join("")
  }

// ==== 搜索的字段 S ==== 
ColumnCommand 'ColumnCommand'
  = '(' __ first:ColumnField rest:MoreColumnFields* __ ')' {
    var renameArr = [];
    var fieldsArr = [];
     
    [first].concat(rest).forEach(item => {
      if(item.length === 2 && item[1]) {
        renameArr.push(item);
      } else {
        fieldsArr.push(item);
      }
    })

    var result = '';
    if(renameArr.length > 0){
      result += `${renameArr.map(item => ` | ${RENAME} ` + (item[0] + ' as ' + item[1])).join(' ')}`
    }
    if(fieldsArr.length > 0) {
      result += ` | ${FIELDS} ${fieldsArr.map(item => item[0]).join(', ')}`
    }
    return result;
  }
  / name:Field+ {
    return ` | ${FIELDS} ${name}`
  }
  / '*' { return '' }

// 字段等
ColumnField
  // name as newName => [name, newName]
  // age => [age, ]
  = oldValue:Field _? AS? _? newValue:Field? {
    return [oldValue, newValue]
  }

MoreColumnFields 'MoreColumnFields'
  = ','? _? field:ColumnField { return field }
// ==== 搜索的字段 E ==== 

// ==== where条件 S ====
WhereCommand 'WhereCommand'
 = '(' __ first:ConditionCommand rest:MoreConditionCommand* __ ')' {
    var arr = [first].concat(rest);
    return arr.join(' ');
}

ConditionCommand
 // 单个条件 mycolumn=value
 = key:Field __ SEP __ value:Value {
	return `${key}=${value}`
	}
  // TODO:
 // LIKE
 / key:Field _ LIKE _ value:Value {
   return `${key}=${value}`
 }
// AND/OR
// BETWEEN

 
MoreConditionCommand 'MoreConditionCommand'
  = _? AND? _? field:ConditionCommand { return field }  
// ==== where条件 E ====

// 数字
Integer "integer"
  = _ [0-9]+ { return parseInt(text(), 10); }

_ = WhitespaceChar+
__ = WhitespaceChar*
WhitespaceChar = [ \t\r\n]

// Glue
SEP = '='

// 字段、表名等
Field = $[a-zA-Z0-9\._\-]+
Value
  = $[a-zA-Z0-9\._\-]+
  / '"' char:Value '"' {
    return char.join('')
  }
  / "'" char:Value "'" {
    return char.join('')
  }
  
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