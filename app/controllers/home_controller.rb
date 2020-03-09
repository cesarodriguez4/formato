# frozen_string_literal: true

require 'docx'
require 'open-uri'

# Clase principal
class HomeController < ApplicationController
  def index
    @file = session[:download] ? true : false
  end

  def create
    # Agregar archivo CSV a Session Storage
    csv_text = File.read(params[:csv])
    session[:csv] = csv_text
    session[:download] = true
    redirect_to :home_index
  end

  # Use some helper method in order to make this code simplier
  def process_file(doc)
    doc.paragraphs.each do |p|
      p.each_text_run do |tr|
        ## Array sobre cada texto, varias veces para modificar cada ocurrencia
        new_text = tr.to_s
        new_arr = process_new_array(new_text, [])
        tr.substitute(tr.to_s, new_arr.join(' '))
      end
    end
    # save the file in session
    doc.save('document.docx')
  end

  def process_new_array(new_text, new_arr)
    csv_values = session[:csv].split(',')
    # Array sobre cada texto, varias veces para modificar cada ocurrencia
    # BUG: El split elimina los espacios en blanco agregados al documento,
    # lo que arruina cualquier diseno compuesto de espacios
    new_text.split.collect do |str|
      if /[…]{2,}|[.]{2,}/.match?(str)
        # Ubica puntos seguidos en el documento
        new_arr << str.sub(/[…]{2,}|[.]{2,}/, csv_values[0])
        csv_values.shift(1)
      else
        new_arr << str
      end
    end
    new_arr
  end

  def download
    # TODO: Reemplazar archivo con url de la base de datos
    buffer = open('https://drive.google.com/uc?export=download&id=1To7UEYG5XImyD5vDinc3zk3yNU2xYXq7')
    doc = Docx::Document.open(buffer)
    process_file(doc) if session[:csv]
    send_file(
      "#{Rails.root}/document.docx",
      filename: 'formato.docx',
      type: 'application/docx'
    )
  end
end
