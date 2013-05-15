class TransactionsController < ApplicationController
    before_filter :authenticate_user!
    filter_access_to :all

    # GET /transactions
    # GET /transactions.json
    def index
        @company = Company.where(:id => current_user.company_id).first
        @transactions = Transaction.all
        @transactions = @company.transactions.paginate(:page => params[:page], :per_page => 15)
        @transaction_fields = current_user.transaction_fields

        respond_to do |format|
            format.html # index.html.erb
            format.json { render json: @transactions }
        end
    end

    # GET /transactions/1
    # GET /transactions/1.json
    def show
        @transaction = Transaction.find(params[:id])

        respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @transaction }
        end
    end

    # GET /transactions/new
    # GET /transactions/new.json
    def new
        @company = Company.where(:id => current_user.company_id).first
        @transaction = Transaction.new
        @contacts = @company.contacts.all
        @transaction_fields = current_user.transaction_fields
        @transaction.contacts.build
        @transaction.product_transactions.build
        @products = Company.find(current_user.company_id).products


        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @transaction }
        end
    end

    # GET /transactions/1/edit
    def edit
        @products = Company.find(current_user.company_id).products
        @company = Company.where(:id => current_user.company_id).first
        @transaction = Transaction.find(params[:id])
        @contacts = @company.contacts.all
        @transaction_fields = current_user.transaction_fields
    end

    # POST /transactions
    # POST /transactions.json
    def create
        @products = Company.find(current_user.company_id).products
        @company = Company.where(:id => current_user.company_id).first
        @transaction = @company.transactions.new(params[:transaction])
        @transaction_fields = current_user.transaction_fields
        @transaction.company_id = @company.id
        @contacts = @company.contacts.all

        respond_to do |format|

            if @transaction.save
                @transaction_fields.each do |tf|
                    TransactionFieldValue.create(:transaction_id => @transaction.id,:transaction_field_value => params[tf.field_name], :transaction_field_id => tf.id)
                end

                if current_user.account_type == 1
                    format.html { redirect_to  transactions_path , notice: 'Transaction was successfully created.' }
                elsif current_user.account_type == 2
                    format.html { redirect_to  leads_path , notice: 'Transaction was successfully created.' }
                elsif current_user.account_type == 3
                    format.html { redirect_to  leads_path , notice: 'Transaction was successfully created.' }
                end
            else
                format.html { render action: "new" }
                format.json { render json: @transaction.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /transactions/1
    # PUT /transactions/1.json
    def update
        @products = Company.find(current_user.company_id).products
        @company = Company.where(:id => current_user.company_id).first
        @transaction = @company.transactions.find(params[:id])
        @transaction_fields = current_user.transaction_fields

        respond_to do |format|
            if @transaction.update_attributes(params[:transaction])
                format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
                format.json { head :no_content }

                @transaction_fields.each do |tf|
                    @transaction_field_value = TransactionFieldValue.where(:transaction_field_id => tf.id, :transaction_id => @transaction.id).first
                    @transaction_field_value.update_attributes(:transaction_id => @transaction.id,:transaction_field_value => params[tf.field_name], :transaction_field_id => tf.id)
                end
            else
                format.html { render action: "edit" }
                format.json { render json: @transaction.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /transactions/1
    # DELETE /transactions/1.json
    def destroy
        @transaction = Transaction.find(params[:id])
        @transaction.destroy

        respond_to do |format|
            format.html { redirect_to transactions_url }
            format.json { head :no_content }
        end
    end

    def mature
        if request.post?
            if params[:executive_type] == "TeamLeader"
                @company_id = TeamLeader.find(params[:matured_by].to_i).company_id
            else
                @company_id = SalesExecutive.find(params[:matured_by].to_i).company_id
            end

            @created = Transaction.last.id
            puts params[:executive_type].to_s
            Transaction.create(:amount => params[:amount],:contact_id => params[:contact_id], :micr_code => params[:micr_code], :transaction_time => params[:transaction_time].to_time, :transaction_type => params[:transaction_type], :company_id => @company_id, :matured_by => params[:matured_by], :executive_type => params[:executive_type].to_s)
            puts params[:executive_type].to_s
            if Transaction.last.id == @created
                session[:errors] = 'Fill the form carefully'
            else
                Lead.find(params[:id1]).update_attributes(:matured_at => params[:transaction_time])
                redirect_to leads_path, notice: "Lead successfully matured"
            end
        end
        @transaction_fields = current_user.transaction_fields
    end

    def graph
        @amounts = Array.new
        @i = 0
        @last_amount = 0


        @transactions = Company.find(current_user.company_id).transactions.where("transaction_time>= \'#{Date.today.at_beginning_of_month.to_time}\' and transaction_time<= \'#{Date.today.at_end_of_month.to_time}\'").order("transaction_time")

        @transactions.each do |transaction|
            @last_amount = @last_amount + transaction.amount
            @amounts[@i] = @last_amount
            @i = @i+1
        end

        @team_leaders = Company.find(current_user.company_id).team_leaders
        @sales_executives = Company.find(current_user.company_id).sales_executives

        @chart = LazyHighCharts::HighChart.new('graph') do |f|
            f.title({ :text=>"Basic line chart"})
            f.options[:xAxis][:categories] = ['Apples', 'Oranges', 'Pears', 'Bananas', 'Plums']
            f.labels(:items=>[:html=>"Total fruit consumption", :style=>{:left=>"40px", :top=>"8px", :color=>"black"} ])      

            f.series(:type=> 'spline',:name=> 'All', :data=> @amounts)
            f.series(:type=> 'spline',:name=> 'Without executive', :data=> [3, 2.67, 3, 6.33, 3.33])
            @team_leaders.each do |tl|
                f.series(:type=> 'spline',:name=> "TL - #{tl.user.full_name}", :data=> [3, 2.67, 3, 6.33, 3.33])
            end
            @sales_executives.each do |se|
                f.series(:type=> 'spline',:name=> "SE - #{se.user.full_name}", :data=> [3, 2.67, 3, 6.33, 3.33])
            end
        end
    end
end
