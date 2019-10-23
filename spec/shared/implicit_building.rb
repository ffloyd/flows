RSpec.shared_examples 'has implicit building' do
  it 'has no prebuild instance initially' do
    expect(subject.default_build).to be_nil
  end

  it 'can be called without instance using YourClass.call' do
    expect(subject.call.unwrap).to eq(data: 'ok')
  end

  it 'saves prebuilt instance after invoke' do
    subject.call
    expect(subject.default_build).not_to be_nil
  end

  context 'with inheritance' do
    let(:child_class) { Class.new(subject) }

    it 'has no prebuild instance initially (even if parent has)' do
      subject.call
      expect(child_class.default_build).to be_nil
    end

    it 'can be called without instance using YourClass.call' do
      expect(child_class.call.unwrap).to eq(data: 'ok')
    end

    it 'saves prebuilt instance after invoke' do
      child_class.call
      expect(child_class.default_build).not_to be_nil
    end
  end
end
