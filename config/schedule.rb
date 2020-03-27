# Every beginning of quarter, we create new invoices for existing PREMIUM companies
#every '0 1 1 1,4,7,10 *' do
every '0 0 * * *' do
  rake "invoices:create_invoice", :output => 'log/invoice_cron.log'
end

# Every day, we check existing invoices status
#every '0 0 * * *' do
every 30.minutes do
  rake "invoices:check_invoice", :output => 'log/invoice_cron.log'
end
# Learn more: http://github.com/javan/whenever
