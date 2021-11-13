using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class QuizzController : MonoBehaviour
{
    public Quizz quizzs;
    public Text Question;
    public Button[] answers;
    private void Start()
    {
        Question.text = quizzs.Question();
        int RightAnswer = Random.Range(0, 4);
        answers[RightAnswer].transform.GetChild(0).GetComponent<Text>().text = quizzs.RightAnswer();
        for(int i=0;i<4; i++)
        {
            int j=0;
            if (i == RightAnswer) continue;
            else { answers[i].transform.GetChild(0).GetComponent<Text>().text = quizzs.FalseAnswers()[j]; j++; }
        }
       
    }

    public void checkAnswer(int indice)
    {
        if (answers[indice].transform.GetChild(0).GetComponent<Text>().text.Equals(quizzs.RightAnswer()))
        {

        }
        else
        {
            answers[indice].gameObject.SetActive(false);
        }
    }
}
