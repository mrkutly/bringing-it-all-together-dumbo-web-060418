class Dog

  attr_accessor :name, :breed, :id

  def initialize(attributes)
    self.assign_attributes(attributes)
  end


  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end


  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog_stats = DB[:conn].execute(sql, id)[0]
    Dog.new(id: dog_stats[0], name: dog_stats[1], breed: dog_stats[2])
  end


  def self.find_by_name_and_breed(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    DB[:conn].execute(sql, name, breed)[0]
  end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dog_stats = DB[:conn].execute(sql, name)[0]
    Dog.new(id: dog_stats[0], name: dog_stats[1], breed: dog_stats[2])
  end


  def self.find_or_create_by(name:, breed:)
    dog_stats = Dog.find_by_name_and_breed(name: name, breed: breed)

    if !dog_stats.nil?
      dog = Dog.new(id: dog_stats[0], name: dog_stats[1], breed: dog_stats[2])
    else
      dog = Dog.create({name: name, breed: breed})
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new({id: row[0], name: row[1], breed: row[2]})
  end

  def assign_attributes(attributes)
    attributes.each do |key, value|
      if self.respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end
  end


  def save
    if !self.id.nil?
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
