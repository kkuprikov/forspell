RSpec.shared_examples 'an error reporter' do
  it 'should report all errors' do
    expect do
      reporter.error(*error)
      reporter.report
    end.to output(printed_output).to_stdout
  end
end

RSpec.shared_examples 'a single error reporter' do
  it 'should report all errors' do
    expect do
      reporter.error(*error)
    end.to output(printed_output).to_stdout
  end
end