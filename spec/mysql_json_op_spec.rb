require 'spec_helper'

Sequel.extension :mysql_json_ops

describe 'Sequel::Mysql::JSONOp' do
  before do
    @db = Sequel.connect('mock://mysql2')
    @j = Sequel.mysql_json_op(:j)
    @l = proc{|o| @db.literal(o)}
  end

  it 'should have #extract accept a path selector' do
    @l[@j.extract('$.foo')].must_equal "JSON_EXTRACT(j, '$.foo')"
    @l[@j.extract('$[0].foo')].must_equal "JSON_EXTRACT(j, '$[0].foo')"
  end
  
  it 'should have #[] accept an Integer as selector for arrays' do
    @l[@j[1]].must_equal "JSON_EXTRACT(j, '$[1]')"
  end

  it 'should have #[] accept a String or Symbol as selector for object attributes' do
    @l[@j['foo']].must_equal "JSON_EXTRACT(j, '$.foo')"
    @l[@j[:bar]].must_equal "JSON_EXTRACT(j, '$.bar')"
  end

  it 'should have #[] merge nested JSON_EXTRACT functions calls into a single one' do
    @l[@j[:items][1][:name]].must_equal "JSON_EXTRACT(j, '$.items[1].name')"
    @l[@j[42][:key]].must_equal "JSON_EXTRACT(j, '$[42].key')"
  end
end
