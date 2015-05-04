UI.registerHelper 'formatDate', (datetime,format) ->
  if moment 
    return moment(datetime).format(format)
  else 
    return datetime

UI.registerHelper 'roundDistance', (dist) ->
  if dist < 900 then return Math.ceil(dist/100)*100+'m'
  if dist < 2500 then return Math.ceil(dist/100)/10+'km'
  if dist < 9000 then return Math.ceil(dist/1000)+'km'
  return Math.ceil(dist/5000)*5+'km'

# function convert2csv(source) converts source.data array to csv
# if defined source.fieldNames array, writes header with fieldNames 
# if defined source.fields, writes rows with data ordered as in source.fields array  
@convert2csv = (source)->
  ret = if source.fieldNames then source.fieldNames.join()+'\n' else ''
  if source.fields 
    writeRow = (row) ->
      cRow = ''
      _compileRow = (f)->
        cRow += if row[f] then row[f]+',' else ','   
      _compileRow field for field in source.fields
      ret += cRow.slice(0,cRow.length-1)+'\n' 
  else
    writeRow = (row) ->
      cRow = ''
      cRow += val+',' for field,val of row
      ret += cRow.slice(0,cRow.length-1)+'\n'    
  writeRow r for r in source.data
  ret += ret.slice 0,ret.length-1 
  return ret