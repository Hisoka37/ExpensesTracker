class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  # GET /expenses or /expenses.json
  def index

 
  if params[:month] && Date::MONTHNAMES.index(params[:month].capitalize)
    month = Date::MONTHNAMES.index(params[:month].capitalize)
    @expenses = Expense.where("extract(month from date) = ?", month)
    @days_in_month = (Date.new(2024, month, 1)..Date.new(2024, month, -1)).map(&:day)
    sum_by_day_hash = @expenses.group_by { |expense| expense.date.day }
                   .transform_values { |expenses| expenses.sum(&:amount) }
    @sum_by_day = @days_in_month.map { |day| sum_by_day_hash[day] || 0 }
  else
    @expenses = Expense.all
  end
    @months = Date.today.all_year.map { |date| date.strftime("%B")}.uniq
    
    @expenses_by_day = @expenses.order(date: :desc).group_by { |expense| expense.date.strftime("%A - %d %B")}
    @expenses_by_month = @expenses.order(date: :desc).group_by { |expense| expense.date.strftime("%Y-%n")}
    @months_amounts = @expenses.map { |expense| { month: expense.date.strftime('%B'), amount: expense.amount } }
    @sum_by_month = @months_amounts.group_by { |entry| entry[:month] }
                              .transform_values { |entries| entries.sum { |e| e[:amount] } }
                              .values

  end

  # GET /expenses/1 or /expenses/1.json
  # GET /expenses/new
  def new  
    @expense = Expense.new
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.new(expense_params)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to expenses_url, notice: "Expense was successfully Created." }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1 or /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to expense_url(@expense), notice: "Expense was successfully updated." }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1 or /expenses/1.json
  def destroy
    @expense.destroy

    respond_to do |format|
      format.html { redirect_to expenses_url, notice: "Expense was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def expense_params
      params.require(:expense).permit(:name, :date, :amount, :description, :category_id)
    end
end
