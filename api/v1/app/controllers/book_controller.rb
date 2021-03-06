require 'sinatra/base'
require 'sinatra/namespace'

class BookController < ApplicationController
  register Sinatra::Namespace

  namespace '/api/v1' do
    before do
      content_type 'application/json'
    end

    get '/books' do
      books = Book.all

      [:title, :isbn, :author].each do |filter|
        books = books.send(filter, params[filter]) if params[filter]
      end

      books.map { |book| Book::BookSerializer.new(book) }.to_json
    end

    get '/books/:id' do |id|
      book = Book.where(id: id).first
      halt(404, { message:'Book Not Found'}.to_json) unless book
      Book::BookSerializer.new(book).to_json
    end

    post '/books' do
      book = Book.new(json_params)
      if book.save
        response.headers['Location'] = "#{base_url}/api/v1/books/#{book.id}"
        status 201
      else
        status 422
        body(Book::BookSerializer.new(book).to_json)
      end
    end

    patch '/books/:id ' do |id|
      book = Book.where(id: id).first
      halt(404, { message:'Book Not Found'}.to_json) unless book
      if book.update_attributes(json_params)
        Book::BookSerializer.new(book).to_json
      else
        status 422
        body Book::BookSerializer.new(book).to_json
      end
    end

    delete '/books/:id' do |id|
      book = Book.where(id: id).first
      book.destroy if book
      status 204
    end

    private

    def serialize(book)
      Book::BookSerializer.new(book).to_json
    end
  end
end
