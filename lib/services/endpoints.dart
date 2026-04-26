class Endpoints {
  static const String baseUrl =
      'https://saccharinely-hormonal-annelle.ngrok-free.dev/api';

  static const String login = '/account/login';
  static const String register = '/Account/register';
  static const String logout = '/account/logout';
  static const String profile = '/account/profile';
  
  // Employee Survey Flow
  static const String questions = '/Survey/questions';
  static const String answers = '/Survey/submit';
  
  // Non-Employee Career Quiz Flow
  static const String careerQuizQuestions = '/CareerQuiz/questions';
  static const String careerQuizFullMatch = '/CareerQuiz/full-match';

  static const String match = '/Matching/find-match';

  // Analysis Proxy Endpoints

  static const String analysisHome = '/AnalysisProxy/home';
  static const String analysisExplore = '/AnalysisProxy/explore';
}