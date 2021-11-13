using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[CreateAssetMenu(fileName ="New Quizz" , menuName ="Quizz")]
public class Quizz : ScriptableObject
{
    [SerializeField] private string question;
    [SerializeField]  private string[] fasleAnsewr;
    [SerializeField]  private string rightAnswer;

    public string Question() { return this.question; }
    public string[] FalseAnswers() { return this.fasleAnsewr; }
    public string RightAnswer() { return this.rightAnswer;  }
}
