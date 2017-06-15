require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?;
    SQL
    new_info = DB[:conn].execute(sql, name).first
    self.new_from_db(new_info)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = #{self.id};
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL


      DB[:conn].execute(sql, self.name, self.grade)

      sql = <<-SQL
        SELECT id FROM students
        ORDER BY id DESC LIMIT 1;
      SQL

      @id = DB[:conn].execute(sql).first.first
    end
  end

  def self.new_from_db(row)
    new_student = self.new(row[1], row[2])
    new_student.id = row[0]
    new_student
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
  end


  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
