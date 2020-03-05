require 'docx'
require 'open-uri'

# /[.]{2,}/
class HomeController < ApplicationController
  def index
    @content = []
    buffer = open('https://drive.google.com/uc?export=download&id=1To7UEYG5XImyD5vDinc3zk3yNU2xYXq7')
    doc = Docx::Document.open(buffer)
    process_file(doc) if session[:csv]
  end

  def create
    csv_text = File.read(params[:csv])
    # Save it in session
    session[:csv] = csv_text
    redirect_to :home_index
  end

  # Use some helper method in order to make this code simplier
  def process_file(doc)
    csv_values = session[:csv].split(',')
    doc.paragraphs.each do |p|
      p.each_text_run do |tr|
        ## Array sobre cada texto, varias veces para modificar cada ocurrencia
        new_text = tr.to_s
        new_arr = []
        new_text.split.collect do |str|
          if /[…]{2,}|[.]{2,}/.match?(str)
            new_arr << str.sub(/[…]{2,}|[.]{2,}/, csv_values[0])
            csv_values.shift(1)
          else
            new_arr << str
          end
        end
        tr.substitute(tr.to_s, new_arr.join(' '))
      end
    end
    doc.save('document.docx')
  end
end
