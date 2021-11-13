using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class debug : MonoBehaviour
{
    public Get2DMovement Get2Axe;
    public Text text;
    /*private void Update()
    {
        if (Get2Axe == null) Get2Axe = FindObjectOfType<Get2DMovement>();

        if (Get2Axe != null) text.text=" "+Get2Axe.MoveDirection();
    }*/
    int A;
    public void SHOW()
    {
        
        this.text.text = "IS ACTIVATING " +A;
        A++;
    }

    internal static void log(int childCount)
    {
        throw new NotImplementedException();
    }

    public void NOTSHOW()
    {
        this.text.text = "NOT SELECTED ";
        A = 0;
    }

}
