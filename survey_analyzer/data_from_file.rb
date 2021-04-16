require("roo")

class DataFromFile

  include Enumerable
  extend Forwardable

  def self.from_path(file_name, file_type, header=nil)
    new(Roo::Spreadsheet.open(file_name, extension: file_type), header)
  end

  def initialize(spreadsheet, header=nil)
    @spreadsheet = spreadsheet
    @spreadsheet.default_sheet = 0
    @header = header || @spreadsheet.row(@spreadsheet.first_row)
  end

  def_delegators :to_enum, :with_index

  def titles
    @header.zip(@spreadsheet.row(1)).to_h
  end

  def each
    @spreadsheet.first_row.next.upto(@spreadsheet.last_row) do |i|
      yield @header.zip(@spreadsheet.row(i)).to_h
    end
  end

end
