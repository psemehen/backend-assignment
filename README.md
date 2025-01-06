## Running the App Locally

1. Make sure `ruby` is installed - version 3.3.6.
2. Run `bundle install` to install dependencies.
3. Run `rspec` to run specs. 
4. Start the server with `rails s`. 
5. The application should be running at `http://localhost:3000`. 

## Room for improvements

1. Update the functionality/refactor `bulk_importer` as it's not really efficient in terms of performance. 
Consider using `activerecord-import` gem to make the request in a bulk and reduce the amount of requests.
2. Improve spec coverage by adding request spec for `bulk_importer` controller.
3. Run the bulk importing async with Sidekiq as an option.
4. Use I18n instead of hardcoding string values.
