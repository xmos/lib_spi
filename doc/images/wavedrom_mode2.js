{ signal: [
  {name: 'CLK',  wave: '1...01010|101...', node: '....B......C......'},
  {name: 'MOSI', wave: 'x..2.2.2.|2.x...', data: ['MSB', '', '', 'LSB'] },
  {name: 'MISO', wave: 'x..2.2.2.|2.x...', data: ['MSB', '', '', 'LSB'], node: '....................' },
  {name: 'SS',   wave: '10.......|...1.0', node: '.A...........D.E..'},
  {              node: '.a..b......c.d.e' }
],
  edge: [ 'A|a','B|b','C|c','D|d','E|e','a<->b t1','c<->d t2', 'd<->e t3' ]
}