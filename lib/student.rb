require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists students(
        id integer,
        name text,
        grade text
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("drop table students")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        insert into students (name, grade)
        values (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = self.new(nil, name, grade)
    student.save
  end

  def self.new_from_db(row)
    student = self.new(*row)
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("select * from students where name = ?", name).first
    self.new_from_db(row)
  end

  def update
    DB[:conn].execute("update students set name = ?, grade = ? where id = ?", self.name, self.grade, self.id)
  end
end
