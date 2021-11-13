using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Piece : MonoBehaviour
{

    public bool isEmpty;
    public int currPos;
    Puzzel puzzel;
    private void Start()
    {
        puzzel = FindObjectOfType<Puzzel>();
    }

    public void Move()
    {
        if ((this.currPos + 1) % 3 != 0 && puzzel.p[currPos + 1].isEmpty) MoveRight();
        else if (this.currPos != 0 && this.currPos % 3 != 0 && puzzel.p[currPos - 1].isEmpty) MoveLeft();
        else if (this.currPos < 6 && puzzel.p[currPos + 3].isEmpty) MoveDown();
        else if (this.currPos > 2 && puzzel.p[currPos - 3].isEmpty) MoveUp();
    }

    private void MoveUp()
    {
        ChangePos(currPos - 3);
    }

    private void MoveDown()
    {
        ChangePos(currPos + 3);
    }

    private void MoveRight()
    {
        ChangePos(currPos + 1);
    }

    private void MoveLeft()
    {
        ChangePos(currPos - 1);
    }

    public void ChangePos(int indice)
    {
        Vector3 Pos = this.transform.position;
        int CurrPosLocal=this.currPos;
        this.transform.position = puzzel.p[indice].gameObject.transform.position;
        puzzel.p[indice].gameObject.transform.position = Pos;

        int aideInt = currPos;
        currPos = indice;
        puzzel.p[indice].currPos = aideInt;


        Piece aide = puzzel.p[CurrPosLocal];
        puzzel.p[CurrPosLocal] = puzzel.p[indice];
        puzzel.p[indice] = aide;
    }
}
