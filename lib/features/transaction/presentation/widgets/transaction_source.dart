String getSourceLabel(String source) {
  switch (source) {
    case 'needs':
      return 'Kebutuhan';
    case 'wants':
      return 'Keinginan';
    case 'savings':
      return 'Tabungan';
    default:
      return source;
  }
}
