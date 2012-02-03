require 'json'

class Contact 
  attr_reader :source , :external_id , :first_name , :middle_name, :last_name , :phones , :emails 

  def initialize args = {}
    args.each do |k,v|
      next if ( k == 'phones' || k == 'emails' ) && v.class != 'Array'
    	instance_variable_set("@#{k}",v) unless v.nil?
    end
  end
  
  #create a json represenation of the contact
  def to_json(options = {},option2 = 0)
    JSON.generate(self.to_hash)
  end
  
  #create a hash represenation of the contact
  def to_hash fields = []
  	hash = {}
  	strip_fields = []
  	self.instance_variables.each{|var| 
  		if fields.length > 0
  			next unless fields.include? var.to_s.delete("@")
  		end
  		hash[var.to_s.delete("@")] = self.instance_variable_get(var) unless strip_fields.include? var.to_s
  	}
  	hash
  end
  
  #create a string representation of the contact
  def to_s
    "First Name: #{first_name}, Middle Name: #{middle_name}, Last Name: #{last_name}, Phones: #{phones}, Emails: #{emails}, Source: #{source} , Id: #{external_id}"
  end
end  