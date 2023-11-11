require 'rails_helper'

RSpec.describe 'POST user_session_path', type: :request do
  describe 'constant sign in execution time after updating work factors' do
    LOW_WORK_FACTORS = { m_cost: 3, t_cost: 1, p_cost: 1 }
    HIGH_WORK_FACTORS = { m_cost: 21, t_cost: 1, p_cost: 4 }

    def time_elapsed(&block)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
    end

    before do
      Devise.paranoid = true
      User.destroy_all
      User.argon2_options = HIGH_WORK_FACTORS 
      User.set_min_hashing_time
    end

    it 'has constant execution time when decreasing cost' do
      user = User.create!(email: 'existing_record@example.invalid', password: '12345678')
      User.argon2_options.merge!(LOW_WORK_FACTORS)

      non_existing_record_time = time_elapsed do
        post(user_session_path, params: { user: { email: 'non existing email', password: 'wrong' }})
      end

      existing_record_time = time_elapsed do
        post(user_session_path, params: { user: { email: user.email, password: 'wrong' }})
      end

      time_difference = (existing_record_time - non_existing_record_time).abs
      expect(time_difference).to be < 0.1
    end

    it 'has constant execution time when increasing cost' do
      User.argon2_options.merge!(LOW_WORK_FACTORS)
      user = User.create!(email: 'existing_record@example.invalid', password: '12345678')
      User.argon2_options.merge!(HIGH_WORK_FACTORS)

      non_existing_record_time = time_elapsed do
        post(user_session_path, params: { user: { email: 'non existing email', password: 'wrong' }})
      end

      existing_record_time = time_elapsed do
        post(user_session_path, params: { user: { email: user.email, password: 'wrong' }})
      end

      time_difference = (existing_record_time - non_existing_record_time).abs
      expect(time_difference).to be < 0.1
    end
  end
end