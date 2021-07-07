require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def update
    sql = "
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    "
    DB[:conn].execute(sql, @name, @grade, @id)
  end

  def save
    @id ? self.update : self.save_new
  end

  def save_new
    sql = "
      INSERT INTO students(name, grade)
      VALUES (?, ?);
    "
    DB[:conn].execute(sql, @name, @grade)
    record = self.class.find_by_name(@name)
    @id = record.id
  end

  def self.new_from_db(attributes)
    self.new(*attributes)
  end

  def self.create_table
    sql = "
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    "
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = self.new(nil, name, grade)
    student.save
  end

  def self.drop_table
    sql = "
      DROP TABLE IF EXISTS students;
    "
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = "
      SELECT *
      FROM students
      WHERE name = ?;
    "
    record = DB[:conn].execute(sql, name).first
    new_from_db(record)
  end

end
