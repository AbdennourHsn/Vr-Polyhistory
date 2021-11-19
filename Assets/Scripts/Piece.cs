using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Piece : MonoBehaviour
{

    public bool isEmpty;
    public int currPos;
    public int rightPosition;
    Puzzel puzzel;

    private void Start()
    {
        puzzel = FindObjectOfType<Puzzel>();
       // canChange = true;
    }

    public void Move()
    {
        if (puzzel.Canmove())
        {
            if ((this.currPos + 1) % 3 != 0 && puzzel.p[currPos + 1].isEmpty) MoveRight();
            else if (this.currPos != 0 && this.currPos % 3 != 0 && puzzel.p[currPos - 1].isEmpty) MoveLeft();
            else if (this.currPos < 6 && puzzel.p[currPos + 3].isEmpty) MoveDown();
            else if (this.currPos > 2 && puzzel.p[currPos - 3].isEmpty) MoveUp();
            
        }

    }

    public void MoveUp()
    {
        if (!isEmpty) ChangePosTween(currPos - 3);
        else changePis(currPos - 3);
    }

    public void MoveDown()
    {
        if (!isEmpty) ChangePosTween(currPos + 3);
        else changePis(currPos + 3);
    }

    public void MoveRight()
    {
        if (!isEmpty) ChangePosTween(currPos + 1);
        else changePis(currPos + 1);
    }

    public void MoveLeft()
    {
        if (!isEmpty) ChangePosTween(currPos - 1);
        else changePis(currPos - 1);
    }

    public void ChangePosTween(int indice)
    {
        Vector3 Pos = this.transform.position;
        int CurrPosLocal=this.currPos;
        LeanTween.move(this.gameObject, puzzel.p[indice].gameObject.transform.position, 1);
        puzzel.SetCanMove(false);
        StartCoroutine(CanChangeOn());
        //this.transform.position = puzzel.p[indice].gameObject.transform.position;
        puzzel.p[indice].gameObject.transform.position = Pos;

        int aideInt = currPos;
        currPos = indice;
        puzzel.p[indice].currPos = aideInt;


        Piece aide = puzzel.p[CurrPosLocal];
        puzzel.p[CurrPosLocal] = puzzel.p[indice];
        puzzel.p[indice] = aide;
    }

    public void changePis(int indice)
    {
        Vector3 Pos = this.transform.position;
        int CurrPosLocal = this.currPos;
       


        this.transform.position = puzzel.p[indice].gameObject.transform.position;
        puzzel.p[indice].gameObject.transform.position = Pos;

        int aideInt = currPos;
        currPos = indice;
        puzzel.p[indice].currPos = aideInt;


        Piece aide = puzzel.p[CurrPosLocal];
        puzzel.p[CurrPosLocal] = puzzel.p[indice];
        puzzel.p[indice] = aide;
    }

    IEnumerator CanChangeOn()
    {
        yield return new WaitForSeconds(1);
        puzzel.SetCanMove(true);
        yield return new WaitForSeconds(0.5f);
        puzzel.check();
    }
}
