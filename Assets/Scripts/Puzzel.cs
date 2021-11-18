using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Puzzel : MonoBehaviour
{
    public Piece[] p;
    private bool canMove;
    private void Start()
    {
        for (int i = 0; i < p.Length; i++)
        {
            p[i].currPos = i;
            p[i].rightPosition = i;
        }
        RandomPuzzel();
        canMove = true;
    }
    public void RandomPuzzel()
    {
        int x = Random.Range(0, p.Length);
        int y = Random.Range(0, p.Length);
        while (p[x].isEmpty) x = Random.Range(0, p.Length);
        while (p[y].isEmpty && x==y) y = Random.Range(0, p.Length);
        Vector3 aideV3 = p[x].transform.position;
        int aideInt = p[x].currPos;

        p[x].transform.position = p[y].transform.position;
        p[x].currPos = p[y].currPos;

        p[y].transform.position = aideV3;
        p[y].currPos = aideInt;
    }
    public void check()
    {

    }
    public void SetCanMove(bool move) { canMove = move; }
    public bool Canmove() { return canMove; }
}
