require 'nokogiri'
require 'open-uri'
require_relative '../contact'

class Contacts
  #specify the number of contacts you need
  MAX_RESULTS = 3000 
  CLIENT_ID = "YOUR CLIENT ID"
  
  #get and parse the contacts with your access token
  def Contacts.get token
    url = "https://www.google.com/m8/feeds/contacts/default/full?client_id=#{CLIENT_ID}&access_token=#{token}&max-results=#{MAX_RESULTS}"
    p url
    
    contacts = [] #keeps track of all the contacts
    
    doc = Nokogiri::HTML(open(url))
    doc.css('entry').each do |item|
      
      #get external id
      base_uri = item.xpath('./id')[0].children.inner_text
      external_id = base_uri.gsub(/^.*\/(\w+)$/,'\1')

      #get contact name
      first_name = ''
      middle_name = ''
      last_name = ''
      name = item.xpath('./title')[0].children.inner_text
      formatted_name_array = name.split
      if formatted_name_array.size == 2
        first_name = formatted_name_array[0]
        last_name = formatted_name_array[1]
      elsif formatted_name_array.size == 3
        first_name = formatted_name_array[0]
        middle_name = formatted_name_array[1]
        last_name = formatted_name_array[2]
      elsif formatted_name_array.size == 1
        first_name = formatted_name_array[0]
      else
        first_name = formatted_name_array[0]
        middle_name = formatted_name_array[1]
        last_name = formatted_name_array[-1]
      end
        
      #get contact email addresses
      email_addresses = []
      i = 0
      item.xpath('./email').each do |email|
        email_addresses << item.xpath('./email')[i].attributes['address'].inner_text
        i+=1
      end
      p email_addresses

      #get phone numbers
      j = 0
      phone_numbers = []
      if item.xpath('./phonenumber')[0] != nil
        item.xpath('./phonenumber').each do |number|
          phone_numbers << item.xpath('./phonenumber')[j].children.inner_text
          i +=1
        end
      end
      p phone_numbers
      
      #create a new contact
      contact = Contact.new({
        :source => 'google',
        :external_id => external_id,
        :first_name => first_name,
        :middle_name => middle_name,
        :last_name => last_name,
        :emails => email_addresses,
        :phones => phone_numbers
      })
      contacts.push( contact  )
    end
    contacts
  end
  
end
    