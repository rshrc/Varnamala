enum ReportReason {
  wrongTranslation('The translation is wrong'),
  unnaturalPhrasing('No one actually says it this way'),
  wrongRomanization('The spelling does not match the sound'),
  wrongAnswer('The marked answer is not correct'),
  other('Something else');

  const ReportReason(this.label);

  final String label;
}
