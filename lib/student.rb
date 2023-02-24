require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT,
        UNIQUE(name)
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      # @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      @id = DB[:conn].last_insert_row_id()
    end

    # self
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end

   def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students 
      WHERE name = ?
    SQL

    # Student.new_from_db(DB[:conn].execute(sql, name)[0])
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE students SET grade = ?, name = ? WHERE id =?
    SQL
    DB[:conn].execute(sql, self.grade, self.name, self.id)
  end
end